Rails.application.routes.draw do
  
  root :to => "application#index"

	resources :survivors, only: [:index, :create, :update, :show] do
  	post :report_infection, on: :member
  end

  resource :reports, only: [] do
  	get 'infected_survivors'
  	get 'uninfected_survivors'
    get 'resources_by_survivor'
    get 'lost_infected_points'
  end

  post :trade, to: 'trades#trade'

  get '*path' => 'application#index'
  
end