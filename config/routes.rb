# frozen_string_literal: true

MyPluginModule::Engine.routes.draw do
  get "/examples" => "examples#index"
  get "/sponsor" => "sponsors#show"
end

Discourse::Application.routes.draw { mount ::MyPluginModule::Engine, at: "/" }
