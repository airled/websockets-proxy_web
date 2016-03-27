WebsocketsProxyWeb::App.controllers :sessions do
  get :new do
    @redirect = params[:redirect]
    render "/sessions/new"
  end

  post :create do
    if account = Account.authenticate(params[:email], params[:password])
      if account.port
        set_current_account(account)
        flash[:success] = "Вы успешно зашли как #{account.email}"
        if params[:redirect].nil?
          redirect url(:welcome, :account)
        else
          redirect "/#{params[:redirect]}"
        end
      else
        redirect url(:welcome, :pending)
      end
    else
      params[:email] = h(params[:email])
      flash[:error] = 'Неправильный email или пароль'
      redirect url(:sessions, :new)
    end
  end

  delete :destroy do
    set_current_account(nil)
    flash[:success] = 'Вы успешно вышли'
    redirect url(:sessions, :new)
  end
end
