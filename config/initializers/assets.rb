# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# ActiveAdmin ships its stylesheet as Sass; compile it via dartsass-rails
# into app/assets/builds so Sprockets can serve it as a static asset.
Rails.application.config.dartsass.builds = { "active_admin.scss" => "active_admin.css" }
