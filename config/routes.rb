# frozen_string_literal: true

DiscourseSponsor::Engine.routes.draw do
  get "/examples" => "examples#index"
  post "/orders" => "orders#create"
  get "/orders/:id/status" => "orders#status"
  post "/orders/:id/status" => "orders#update_status"
  # define routes here
  get "/" => "sponsors#show"
end

Discourse::Application.routes.draw do
  mount ::DiscourseSponsor::Engine, at: "/sponsor", as: "discourse_sponsor"
end
