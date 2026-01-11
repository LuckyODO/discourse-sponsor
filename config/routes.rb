# frozen_string_literal: true

MyPluginModule::Engine.routes.draw do
  get "/examples" => "examples#index"
  post "/orders" => "orders#create"
  # define routes here
  get "/sponsor" => "sponsors#show"
end

Discourse::Application.routes.draw { mount ::MyPluginModule::Engine, at: "my-plugin" }
Discourse::Application.routes.append do
  post "/sponsor/orders" => "my_plugin_module/sponsor_orders#create"
end
Discourse::Application.routes.draw { mount ::MyPluginModule::Engine, at: "/" }
