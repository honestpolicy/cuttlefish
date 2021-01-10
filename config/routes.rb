# frozen_string_literal: true

# == Route Map
#
#                    Prefix Verb   URI Pattern                                                                              Controller#Action
#            graphiql_rails        /graphiql                                                                                GraphiQL::Rails::Engine {:graphql_path=>"/graphql"}
#                   graphql POST   /graphql(.:format)                                                                       graphql#execute
#         new_admin_session GET    /admins/sign_in(.:format)                                                                admins/sessions#new
#             admin_session POST   /admins/sign_in(.:format)                                                                admins/sessions#create
#     destroy_admin_session DELETE /admins/sign_out(.:format)                                                               admins/sessions#destroy
#    new_admin_registration GET    /admins/sign_up(.:format)                                                                admins/registrations#new
#   edit_admin_registration GET    /admins/edit(.:format)                                                                   admins/registrations#edit
#        admin_registration PATCH  /admins(.:format)                                                                        admins/registrations#update
#                           PUT    /admins(.:format)                                                                        admins/registrations#update
#                           DELETE /admins(.:format)                                                                        admins/registrations#destroy
#                           POST   /admins(.:format)                                                                        admins/registrations#create
#   accept_admin_invitation GET    /admins/invitation/accept(.:format)                                                      invitations#edit
#          admin_invitation PATCH  /admins/invitation(.:format)                                                             invitations#update
#                           PUT    /admins/invitation(.:format)                                                             invitations#update
#                           POST   /admins/invitation(.:format)                                                             invitations#create
#        new_admin_password GET    /admins/password/new(.:format)                                                           admins/passwords#new
#       edit_admin_password GET    /admins/password/edit(.:format)                                                          admins/passwords#edit
#            admin_password PATCH  /admins/password(.:format)                                                               admins/passwords#update
#                           PUT    /admins/password(.:format)                                                               admins/passwords#update
#                           POST   /admins/password(.:format)                                                               admins/passwords#create
#                    admins GET    /admins(.:format)                                                                        admins#index
#                     admin DELETE /admins/:id(.:format)                                                                    admins#destroy
#                deliveries GET    /emails(.:format)                                                                        deliveries#index
#                  delivery GET    /emails/:id(.:format)                                                                    deliveries#show
#              from_address GET    /addresses/:id/from(.:format)                                                            addresses#from {:id=>/[^\/]+/}
#                to_address GET    /addresses/:id/to(.:format)                                                              addresses#to {:id=>/[^\/]+/}
#               test_emails POST   /test_emails(.:format)                                                                   test_emails#create
#            new_test_email GET    /test_emails/new(.:format)                                                               test_emails#new
#            app_deliveries GET    /apps/:app_id/emails(.:format)                                                           deliveries#index
#               app_clients GET    /apps/:app_id/clients(.:format)                                                          clients#index
#            app_deny_lists GET    /apps/:app_id/deny_lists(.:format)                                                       deny_lists#index
#             app_deny_list DELETE /apps/:app_id/deny_lists/:id(.:format)                                                   deny_lists#destroy
#                  dkim_app GET    /apps/:id/dkim(.:format)                                                                 apps#dkim
#               webhook_app GET    /apps/:id/webhook(.:format)                                                              apps#webhook
#           toggle_dkim_app POST   /apps/:id/toggle_dkim(.:format)                                                          apps#toggle_dkim
#          upgrade_dkim_app POST   /apps/:id/upgrade_dkim(.:format)                                                         apps#upgrade_dkim
#                      apps GET    /apps(.:format)                                                                          apps#index
#                           POST   /apps(.:format)                                                                          apps#create
#                   new_app GET    /apps/new(.:format)                                                                      apps#new
#                  edit_app GET    /apps/:id/edit(.:format)                                                                 apps#edit
#                       app GET    /apps/:id(.:format)                                                                      apps#show
#                           PATCH  /apps/:id(.:format)                                                                      apps#update
#                           PUT    /apps/:id(.:format)                                                                      apps#update
#                           DELETE /apps/:id(.:format)                                                                      apps#destroy
#                deny_lists GET    /deny_lists(.:format)                                                                    deny_lists#index
#                 deny_list DELETE /deny_lists/:id(.:format)                                                                deny_lists#destroy
#              invite_teams POST   /teams/invite(.:format)                                                                  teams#invite
#                     teams GET    /teams(.:format)                                                                         teams#index
#                   clients GET    /clients(.:format)                                                                       clients#index
#                      root GET    /                                                                                        landing#index
#                      dash GET    /dash(.:format)                                                                          main#index
#             status_counts GET    /status_counts(.:format)                                                                 main#status_counts
#                reputation GET    /reputation(.:format)                                                                    main#reputation
#             tracking_open GET    /o2/:delivery_id/:hash(.:format)                                                         tracking#open
#            tracking_click GET    /l2/:delivery_link_id/:hash(.:format)                                                    tracking#click
#             documentation GET    /documentation(.:format)                                                                 documentation#index
#        rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
# rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#        rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
# update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#      rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create
#
# Routes for GraphiQL::Rails::Engine:
#        GET  /           graphiql/rails/editors#show

Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql" if Rails.env.development?
  post "/graphql", to: "graphql#execute"
  devise_for :admins, only: []

  resource :session,
           only: [],
           as: "admin_session",
           path: "/admins",
           controller: "admins/sessions" do
    get :new, path: "sign_in", as: "new"
    post :create, path: "sign_in"
    match :destroy, path: "sign_out", as: "destroy", via: :delete
  end

  resource :registration,
           only: %i[new create edit update destroy],
           as: "admin_registration",
           path: "/admins",
           controller: "admins/registrations",
           path_names: { new: "sign_up" }

  resource :invitation,
           only: %i[create update],
           as: "admin_invitation",
           path: "/admins/invitation" do
    get :edit, path: "accept", as: :accept
  end

  resource :password,
           only: %i[new create edit update],
           as: "admin_password",
           path: "/admins/password",
           controller: "admins/passwords"

  # TODO: the sidekiq ui should be part of the API part of Cuttlefish and not
  # part of the admin interface
  # We want to get rid of the use of sidekiq (by making the smtp server talk
  # to cuttlefish via the graphql api) and there is no immediate super easy
  # way to do authentication and check that the user is a site_admin.
  # So, disabling it for the moment. Let's hope we don't need it in an emergency
  # require "sidekiq/web"
  # authenticate :admin, ->(u) { u.site_admin? } do
  #   mount Sidekiq::Web => "/sidekiq"
  # end

  resources :admins, only: %i[index destroy]
  resources :emails, only: %i[index show], as: :deliveries,
                     controller: "deliveries"
  # Allow "." in the id's by using the constraint
  resources :addresses, only: [], constraints: { id: %r{[^/]+} } do
    member do
      get :from
      get :to
    end
  end
  resources :test_emails, only: %i[new create]
  resources :apps do
    resources :emails, only: :index, as: :deliveries, controller: "deliveries"
    resources :clients, only: :index, as: :clients, controller: "clients"
    resources :deny_lists, only: %i[index destroy], as: :deny_lists, controller: "deny_lists"

    member do
      get "dkim"
      get "webhook"
      post "toggle_dkim"
      post "upgrade_dkim"
    end
  end

  resources :deny_lists, only: %i[index destroy]
  resources :teams, only: :index do
    collection do
      post "invite"
    end
  end

  resources :clients, only: :index

  root to: "landing#index"

  get "dash" => "main#index"
  get "status_counts" => "main#status_counts"
  get "reputation" => "main#reputation"

  # Open tracking gifs
  get "o2/:delivery_id/:hash" => "tracking#open", as: "tracking_open"

  # Link tracking
  get "l2/:delivery_link_id/:hash" => "tracking#click", as: "tracking_click"

  get "/documentation" => "documentation#index"
end
