# Template Name: Landing page template
# Author: Magnus S. Remøe
# Author URI: https://www.github.com/cestbalez/
# Instructions: $ rails new project-name -d postgresql -css tailwind -m template.rb

def add_gems
  gem 'browser'
  gem 'meta-tags'
  gem_group :development do
    gem 'htmlbeautifier'
  end
  gem_group :development, :test do
    gem 'byebug'
  end
end

def set_application_name
  application_name = ask("What is the name of your application? Default: Landing")

  environment "config.application_name = '#{application_name.presence || "Landing"}'"

  puts "Your application name is #{application_name}. You can change this later on: ./config/application.rb"
end

def copy_templates
  directory 'app', force: true
end

def set_default_meta_tags
  puts 'Setting meta tags for SEO'
  website = ask('What is the name of your site? Default: Landing')
  title = ask('Provide a title? Example: Improving surfing skills')
  description = ask('Provide a short description? Example: The marketplace for surf coaching')
  keywords = ask('Do you already know your keywords? Example: learn surfing, surf coach, surf instructor, surf jobs')

  content = <<~RUBY
    def default_meta_tags
      {
        site: "#{website}.presence || 'Landing'",
        title: "#{title}",
        reverse: true,
        separator: '|',
        description: "#{description}",
        keywords: "#{keywords}",
        canonical: request.original_url,
        noindex: !Rails.env.production?,
        icon: [
          { href: image_url('favicon.png') },
          { href: image_url('favicon.png'), rel: 'apple-touch-icon', sizes: '180x180', type: 'image/jpg' },
        ],
        og: {
          site_name: "#{website}.presence || 'Landing'",
          title: "#{title}",
          description: "#{description}", 
          type: 'website',
          url: request.original_url,
          image: image_url('og_banner.jpg')
        }
      }
    end
  RUBY

  insert_into_file 'app/helpers/application_helper.rb', "#{content}\n", after: "module ApplicationHelper\n"
end

def add_waiting_list
  generate :model, 'WaitingListUser', 'email:string'

  content = <<~RUBY
    validates :email,
      presence: true,
      uniqueness: true,
      format: { with: URI::MailTo::EMAIL_REGEXP }
  RUBY

  insert_into_file(
    'app/models/waiting_list_user.rb',
    "#{content}\n",
    after: "class WaitingListUser < ApplicationRecord\n"
  )

  route 'resources :waiting_list_users, only: [:create]'
end

def configure_environments
  environment 'config.hosts << ->(host) { host.include?("ngrok.io") }',
              env: :development
  environment 'config.force_ssl = true',
              env: :production
end

def set_routes
  route "root to: 'landing#show'"
  route 'resource :landing, only: [:show]'
end

def copy_files
  copy_file 'docker-compose.yml'
  copy_file 'Procfile'
end

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

add_gems

after_bundle do
  set_application_name
  add_waiting_list
  configure_environments
  set_routes
  set_default_meta_tags
  copy_files

  # Make sure Linux is in the Gemfile.lock for deploying
  run 'bundle lock --add-platform x86_64-linux'

  copy_templates

  # Commit everything to git
  git :init
  git add: '.'
  git commit: %( -m 'Initial commit' )
  run 'gh repo create'

  say 'Landing page successfully created!', :blue

  say 'Setting up database', :blue

  run 'docker-compose up'
  run 'rails db:create db:migrate'
end