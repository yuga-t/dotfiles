-- git.yazi: ファイル一覧にgitの差分状態を表示 (yazi.toml の prepend_fetchers と対)
require("git"):setup({
	order = 1500,
})

-- starship.yazi: ヘッダーにstarshipプロンプトを表示
require("starship"):setup()
