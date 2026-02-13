return {
	{
		"yetone/avante.nvim",
		opts = {
			provider = "gemini",
			mode = "legacy",

			providers = {
				gemini = {
					endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
					model = "gemini-3-flash-preview",
					timeout = 30000,
					api_key_name = "AVANTE_GEMINI_API_KEY",
				},

				openai = {
					endpoint = "https://api.openai.com/v1",
					model = "gpt-5.2",
					timeout = 30000,
					api_key_name = "AVANTE_OPENAI_API_KEY",
				},
			},
		},
	},
}
