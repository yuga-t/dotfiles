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
. "$HOME/.cargo/env"

# aqua
if [ -d "${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin" ]; then
    export PATH=${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH
fi

if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml" ]; then
    export AQUA_GLOBAL_CONFIG=${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml
fi
