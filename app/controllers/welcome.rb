WebsocketsProxyWeb::App.controllers :welcome do
  
  get :index, :map => '/' do
    render 'index'
  end

  get :docs, :map => '/docs' do
    render 'docs'
  end

  get :contacts, :map => '/contacts' do
    render 'contacts'
  end

  get :profile, :map => '/profile' do
    if current_account
      render 'profile'
    else
      flash[:warning] = 'Авторизируйтесь, чтобы войти в профиль'
      redirect '/sessions/new?redirect=profile'
    end
  end

  get :plugin, :map => '/plugin' do
    name = Dir.glob('public/*.xpi').first.split('/')[1]
    send_file "public/#{name}", filename: "#{name}"
  end

  get :pending, :map => '/pending' do
    render 'pending'
  end

  get :message, :map => '/message' do
    if current_account
      render 'message'
    else
      flash[:warning] = 'Авторизируйтесь, чтобы отправить сообщение'
      redirect '/sessions/new?redirect=message'
    end
  end

  post :message, :map => '/message' do
    if current_account
      email(
        from: ENV['EMAIL_NAME'],
        to: ENV['EMAIL_NAME'],
        subject: "User's message",
        body: "User #{current_account.email} says:\n#{params[:body]}"
      )
      flash[:success] = 'Ваше сообщение отправлено'
      redirect '/'
    else
      status 403
    end
  end

  get :create_user, :map => '/create_user' do
    render 'create_user'
  end

  post :create_user, :map => '/create_user' do
    account = Account.new(:email => params[:email], :password => params[:password], :password_confirmation => params[:password_confirmation], :role => "user", :confirmed => false, :queue => nil, :port => nil)
    if account.valid?
      account.save
      email(
        from: ENV['EMAIL_NAME'],
        to: ENV['EMAIL_NAME'],
        subject: 'New user registered',
        body: "User #{account.email} has been registered.\nhttp://bproxy.muzenza.by/admin/accounts/confirm/#{account.id}"
      ) if Padrino.env == :production
      set_current_account(nil) if current_account
      flash[:success] = 'Ваш аккаунт успешно создан'
      redirect '/pending'
    else
      flash[:error] = account.errors.full_messages.each { |m| p "   - #{m}" }.join("\n")
      redirect '/create_user'
    end
  
  end

end
