# frozen_string_literal: true

MyPluginModule::Engine.routes.draw do
  get "/examples" => "examples#index"
  post "/orders" => "orders#create"
  # define routes here
end

Discourse::Application.routes.draw { mount ::MyPluginModule::Engine, at: "my-plugin" }
