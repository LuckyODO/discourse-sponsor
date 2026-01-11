# frozen_string_literal: true

DiscourseSponsor::Engine.routes.draw do
  get "/examples" => "examples#index"
  post "/orders" => "orders#create"
  # define routes here
  get "/" => "sponsors#show"
end

Discourse::Application.routes.draw do
  mount ::DiscourseSponsor::Engine, at: "/sponsor", as: "discourse_sponsor"
end
Discourse::Application.routes.append do
  post "/sponsor/orders" => "discourse_sponsor/sponsor_orders#create"
end
