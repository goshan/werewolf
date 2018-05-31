Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'pages#game'

  get 'login', :to => "pages#login", :as => :login
  post 'signin', :to => "pages#signin", :as => :signin
  post 'logout', :to => "pages#logout", :as => :logout
  put 'setting', :to => "pages#setting", :as => :setting

  resource :wx do
    post 'login'
    get 'rule'
    get 'setting'
    post 'update_setting'
  end
end
