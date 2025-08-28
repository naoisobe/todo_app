# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Ensure Propshaft serves build outputs (e.g. Tailwind compiled CSS)
Rails.application.config.assets.paths << Rails.root.join("app/assets/builds")

# Ensure the compiled Tailwind build (app/assets/builds/tailwind.css)
# is included in the precompile output as `tailwind-<digest>.css` so
# the production public/assets contains the compiled file.
Rails.application.config.assets.precompile += ["tailwind.css"]
