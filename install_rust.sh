#!/bin/bash
##not really a working script
##more like a recipe
curl https://sh.rustup.rs -sSf | sh
#Add to end of .bashrc
# export PATH=$PATH:$HOME/.cargo/bin
cargo install rustfmt
carto install racer
rustup component add rust-src
rustup completions bash > rustup.bash-completion
rm rustup.bash-completion
sudo cp rustup.bash-completion /etc/bash_completion.d/
sudo add-apt-repository ppa:webupd8team/atom
sudo apt update
sudo apt install atom
apm install language-rust linter-rust linter racer rustfmt tokamak build-cargo atom-beautify build busy linter-ui-default intentions busy-signal tokamak-terminal tool-bar
# open racer settings and set path to src as
# .multirust/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src

