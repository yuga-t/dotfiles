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

# mise (universal version manager)
if [ -d "$HOME/.local/share/mise/shims" ]; then
    export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

# android studio
if [ -d "/usr/local/android-studio/jbr" ]; then
    export JAVA_HOME=/usr/local/android-studio/jbr
    export PATH=$JAVA_HOME/bin:$PATH
fi

# local override
[ -f "$HOME/.zshenv.local" ] && source "$HOME/.zshenv.local"
