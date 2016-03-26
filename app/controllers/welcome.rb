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

  get :account, :map => '/account' do
    if current_account
      @profiles = current_account.profiles
      render 'account'
    else
      flash[:warning] = 'Авторизируйтесь, чтобы войти в профиль'
      redirect '/sessions/new?redirect=account'
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
      send_email("User's message", "User #{current_account.email} says:\n#{params[:body]}")
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
    account = Account.new(email: params[:email], password: params[:password], password_confirmation: params[:password_confirmation], :role => "user", :confirmed => false, :port => nil)
    if account.valid?
      account.save
      account.add_default_profile
      send_email('New user registered', "User #{account.email} has been registered.\nhttp://bproxy.muzenza.by/admin/accounts/confirm/#{account.id}")
      set_current_account(nil) if current_account
      flash[:success] = 'Ваш аккаунт успешно создан'
      redirect '/pending'
    else
      flash[:error] = account.errors.full_messages.each { |m| p "   - #{m}" }.join("\n")
      redirect '/create_user'
    end
  end

  post :create_profile, map: '/create_profile' do
    if params[:name] == '' || params[:name].include?(' ')
      flash[:error] = 'Неправильное имя профиля'
    elsif !Profile.where(account_id: current_account.id, name: params[:name]).first.nil?
      flash[:error] = 'Профиль с таким именем уже существует'
    else
      current_account.add_profile(name: params[:name], queue: generate_uniq_queue)
      flash[:success] = 'Профиль создан'
    end
    redirect url(:welcome, :account)
  end

  delete :remove_profile, map: '/remove_profile' do
    Profile[params[:profile_id]].destroy
    redirect url(:welcome, :account)
  end

  patch :rename_profile, map: '/rename_profile' do
    Profile[params[:profile_id]].update(name: params[:name])
    redirect url(:welcome, :account)
  end

end
