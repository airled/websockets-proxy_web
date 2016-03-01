WebsocketsProxyWeb::App.controllers :sessions do
  get :new do
    render "/sessions/new"
  end

  post :create do
    if account = Account.authenticate(params[:email], params[:password])
      if account.confirmed?
        set_current_account(account)
        flash[:success] = "Вы успешно зашли как #{account.email}"
        redirect '/profile'
      else
        redirect '/pending'
      end
    else
      params[:email] = h(params[:email])
      flash[:error] = 'Неправильный email или пароль'
      redirect "/sessions/new"
    end
  end

  delete :destroy do
    set_current_account(nil)
    flash[:success] = 'Вы успешно вышли'
    redirect url(:sessions, :new)
  end
end
