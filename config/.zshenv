# PATH
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
if [ -d "/usr/local/go/bin" ]; then
    export PATH="/usr/local/go/bin:$PATH"
fi
if [ -d "$HOME/go/bin" ]; then
    export PATH="$HOME/go/bin:$PATH"
fi

# Rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Android Studio
if [ -d "/usr/local/android-studio/jbr" ]; then
    export JAVA_HOME=/usr/local/android-studio/jbr
    export PATH="$JAVA_HOME/bin:$PATH"
fi

# local override
[ -f "$HOME/.zshenv.local" ] && source "$HOME/.zshenv.local"
