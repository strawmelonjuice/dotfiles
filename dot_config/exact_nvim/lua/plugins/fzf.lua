return {
    {"junegunn/fzf.vim"},
    -- If not working, run:
    -- git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    -- ~/.fzf/install
    { "junegunn/fzf", dir = "~/.fzf", build = "./install --all" }
}