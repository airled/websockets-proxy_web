WebsocketsProxyWeb::App.controllers :welcome do
  
  get :index, :map => '/' do
    render 'index'
  end

  get :profile, :map => '/profile' do
    if current_account
      render 'profile'
    else
      redirect '/sessions/new'
    end
  end

  get :plugin, :map => '/plugin' do
    send_file 'public/@websockets-proxy-0.1.0.xpi', filename: 'plugin.xpi'
  end

  get :pending, :map => '/pending' do
    render 'pending'
  end

  get :create_user, :map => '/create_user' do
    render 'create_user'
  end

  post :create_user, :map => '/create_user' do
    account = Account.new(:email => params[:email], :password => params[:password], :password_confirmation => params[:password], :role => "user", :confirmed => false, :queue => nil, :port => nil)
    if account.valid?
      account.save
      email(
        from: ENV['EMAIL_NAME'],
        to: ENV['EMAIL_NAME'],
        subject: 'New user registered',
        body: "User #{account.email} has been registered.\nhttp://bproxy.muzenza.by/admin/accounts/edit/#{account.id}"
      ) if Padrino.env == :production
      set_current_account(nil) if current_account
      render 'pending'
    else
      account.errors.full_messages.each { |m| p "   - #{m}" }
    end
  
  end

end
