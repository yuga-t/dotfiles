# local bin
if [ -d "$HOME/.local/bin" ]; then
    export PATH=$HOME/.local/bin:$PATH
fi

# go
if [ -d "/usr/local/go/bin" ] && [ -d "$HOME/go/bin" ]; then
    export PATH=/usr/local/go/bin:$PATH
    export PATH=$HOME/go/bin:$PATH
fi

# rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# fnm (Node version manager)
if [ -d "$HOME/.local/share/fnm" ]; then
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd --shell zsh)"
fi

# aqua
if [ -d "${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin" ]; then
    export PATH=${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH
fi

if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml" ]; then
    export AQUA_GLOBAL_CONFIG=${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml
fi

# android studio
if [ -d "/usr/local/android-studio/jbr" ]; then
    export JAVA_HOME=/usr/local/android-studio/jbr
    export PATH=$JAVA_HOME/bin:$PATH
fi

# bun
if [ -d "$HOME/.bun" ] && [ -d "$HOME/.bun/bin" ]; then
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# local override
[ -f "$HOME/.zshenv.local" ] && source "$HOME/.zshenv.local"
