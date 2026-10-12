# ==============================================================================
#  Lutgen Interactive Wallpaper Recoloring Utility
# ==============================================================================

_lutgen_resolve_target() {
    local target="$1"
    # Trim leading/trailing whitespace
    target="${target#"${target%%[![:space:]]*}"}"
    target="${target%"${target##*[![:space:]]}"}"
    # Strip enclosing single or double quotes
    if [[ ( "$target" == \'*\' && "$target" == *\' ) || ( "$target" == \"*\" && "$target" == *\" ) ]]; then
        target="${target[2,-2]}"
    fi
    # Expand tilde
    target="${target/#\~/$HOME}"
    [[ "$target" != "/" ]] && target="${target%/}"

    if [[ -e "$target" ]]; then
        print -r -- "$target"
    elif [[ -e "$HOME/Pictures/noctalia-walls/$target" ]]; then
        print -r -- "$HOME/Pictures/noctalia-walls/$target"
    elif [[ -e "$HOME/Pictures/$target" ]]; then
        print -r -- "$HOME/Pictures/$target"
    else
        print -r -- "$target"
    fi
}

lutgen() {
    # 1. Passthrough for built-in subcommands and flags (-V, --help, apply, etc.)
    if [[ $# -gt 0 ]]; then
        case "$1" in
            -*|apply|generate|extract|patch|palette)
                command lutgen "$@"
                return $?
                ;;
        esac
    fi

    local palettes_dir="${XDG_CONFIG_HOME:-$HOME/.config}/lutgen"
    local output_base="$HOME/Pictures/noctalia-walls"
    local pictures_dir="$HOME/Pictures/noctalia-walls"

    if [[ ! -d "$palettes_dir" ]]; then
        echo -e "\033[1;31m✘ Palettes directory not found:\033[0m $palettes_dir"
        return 1
    fi

    # 2. Collect input files if arguments were passed
    local -a input_files=()

    if [[ $# -gt 0 ]]; then
        for raw_arg in "$@"; do
            local target="$(_lutgen_resolve_target "$raw_arg")"

            if [[ ! -e "$target" ]]; then
                echo -e "\033[1;31m✘ Target not found:\033[0m $raw_arg"
                return 1
            fi

            # Check if target is a file or a folder
            if [[ "$target" =~ \.(png|jpg|jpeg|webp|avif|bmp|PNG|JPG|JPEG|WEBP|AVIF|BMP)$ ]] || [[ -f "$target" ]]; then
                input_files+=("$target")
            else
                # It's a folder: collect all images recursively
                if command -v fd >/dev/null 2>&1; then
                    local -a found=(${(@f)"$(fd -t f -e png -e jpg -e jpeg -e webp -e avif -e bmp . "$target")"})
                else
                    local -a found=(${(@f)"$(find "$target" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.avif" -o -iname "*.bmp" \))"})
                fi
                for f in "${found[@]}"; do
                    [[ -n "$f" ]] && input_files+=("$f")
                done
            fi
        done

        input_files=(${(ou)input_files})
        if [[ ${#input_files[@]} -eq 0 ]]; then
            echo -e "\033[1;31m✘ No image files found in specified target(s).\033[0m"
            return 1
        fi
    fi

    # 3. Palette Multi-Selection with fzf
    local -a available_palettes=()
    for p in "$palettes_dir"/*.txt(N); do
        available_palettes+=("$(basename "$p" .txt)")
    done

    if [[ ${#available_palettes[@]} -eq 0 ]]; then
        echo -e "\033[1;31m✘ No custom palettes found in $palettes_dir\033[0m"
        return 1
    fi

    local selected_raw
    selected_raw=$(printf "%s\n" "${available_palettes[@]}" | sort | fzf -m \
        --ansi \
        --prompt="🎨 Select Palette(s) > " \
        --header="[TAB]: Multi-select | [ENTER]: Confirm | [ESC]: Cancel" \
        --preview="command lutgen palette --ansi {} 2>/dev/null" \
        --preview-window=right:45%:wrap)

    [[ -z "$selected_raw" ]] && return 0
    local -a selected_palettes=("${(@f)selected_raw}")

    # 4. If no target argument was passed, open fzf wallpaper browser across ~/Pictures
    if [[ ${#input_files[@]} -eq 0 ]]; then
        local selected_images_raw
        if command -v fd >/dev/null 2>&1; then
            selected_images_raw=$( (cd "$pictures_dir" && fd -t f -e png -e jpg -e jpeg -e webp -e avif -e bmp) | fzf -m \
                --height=80% \
                --prompt="🖼  Select Wallpaper(s) > " \
                --header="[TAB]: Multi-select | [ENTER]: Confirm | [ESC]: Cancel" \
                --preview="lutgen-preview {}" \
                --preview-window=right:55%:wrap)
        else
            selected_images_raw=$( (cd "$pictures_dir" && find . -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.avif" -o -iname "*.bmp" \) | sed 's|^\./||') | fzf -m \
                --height=80% \
                --prompt="🖼  Select Wallpaper(s) > " \
                --header="[TAB]: Multi-select | [ENTER]: Confirm | [ESC]: Cancel" \
                --preview="lutgen-preview {}" \
                --preview-window=right:55%:wrap)
        fi

        [[ -z "$selected_images_raw" ]] && return 0

        for rel in "${(@f)selected_images_raw}"; do
            if [[ -n "$rel" ]]; then
                [[ "$rel" = /* ]] && input_files+=("$rel") || input_files+=("$pictures_dir/$rel")
            fi
        done

        input_files=(${(ou)input_files})
        if [[ ${#input_files[@]} -eq 0 ]]; then
            return 0
        fi
    fi

    # 5. Recoloring Execution
    local total_tasks=$(( ${#selected_palettes[@]} * ${#input_files[@]} ))
    echo ""
    echo -e "\033[1;35m🚀 Starting recoloring: ${#selected_palettes[@]} palette(s) × ${#input_files[@]} image(s) = $total_tasks output(s)\033[0m"
    echo ""

    local -a recolored_images=()
    local current_task=0

    for pal in "${selected_palettes[@]}"; do
        local dest_dir="$output_base/$pal"
        mkdir -p "$dest_dir"

        # Determine sequence index: find highest existing ${pal}-<N>.*
        local max_idx=0
        for f in "$dest_dir"/"$pal"-*.*(N); do
            local bname="$(basename "$f")"
            if [[ "$bname" =~ ^${pal}-([0-9]+)\.[a-zA-Z0-9]+$ ]]; then
                local num="${match[1]}"
                (( num > max_idx )) && max_idx=$num
            fi
        done

        for img in "${input_files[@]}"; do
            (( current_task++ ))
            (( max_idx++ ))
            local out_file="$dest_dir/${pal}-${max_idx}.png"

            printf "\033[36m[%d/%d]\033[0m Applying \033[33m%s\033[0m to \033[37m%s\033[0m... " \
                "$current_task" "$total_tasks" "$pal" "$(basename "$img")"

            if command lutgen apply -p "$pal" -o "$out_file" "$img" > /dev/null 2>&1; then
                echo -e "\033[32m✔\033[0m -> \033[32m${pal}-${max_idx}.png\033[0m"
                recolored_images+=("$out_file")
            else
                echo -e "\033[31m✘ Failed\033[0m"
            fi
        done
    done

    local count=${#recolored_images[@]}
    if [[ $count -eq 0 ]]; then
        echo -e "\n\033[1;31m✘ No images were successfully recolored.\033[0m"
        return 1
    fi

    echo ""
    echo -e "\033[1;32m🎉 Recoloring Complete!\033[0m \033[90m($count files generated in $output_base)\033[0m"

    # 6. Terminal Image Previews (1 for 1, 2 for 2, 3 for >= 3)
    local -a preview_list=()
    if [[ $count -eq 1 ]]; then
        preview_list=("${recolored_images[1]}")
    elif [[ $count -eq 2 ]]; then
        preview_list=("${recolored_images[1]}" "${recolored_images[2]}")
    else
        local idx1=1
        local idx2=$(( count / 2 + 1 ))
        local idx3=$count
        preview_list=("${recolored_images[idx1]}" "${recolored_images[idx2]}" "${recolored_images[idx3]}")
    fi

    echo ""
    echo -e "\033[1;36m🖼  Displaying Preview (${#preview_list[@]} of $count):\033[0m"
    local p_idx=1
    for p_img in "${preview_list[@]}"; do
        echo -e "\n\033[1;33m[$p_idx/${#preview_list[@]}]\033[0m \033[1m$(basename "$p_img")\033[0m \033[90m($p_img)\033[0m"
        lutgen-preview "$p_img"
        (( p_idx++ ))
    done
    echo ""
}
