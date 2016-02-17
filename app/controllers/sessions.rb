WebsocketsProxyWeb::App.controllers :sessions do
  get :new do
    render "/sessions/new", nil, :layout => false
  end

  post :create do
    if account = Account.authenticate(params[:email], params[:password])
      set_current_account(account)
      # if current_account.confirmed?
        redirect '/profile'
      # else
      #   redirect '/pending'
      # end
    else
      params[:email] = h(params[:email])
      redirect "/sessions/new", nil, :layout => false
    end
  end

  delete :destroy do
    set_current_account(nil)
    redirect url(:sessions, :new)
  end
end
