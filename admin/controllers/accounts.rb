def generate_uniq_queue
  require 'securerandom'
  queue = ''
    loop do
      current_queue = SecureRandom.hex
      if Profile[queue: current_queue].nil?
        queue = current_queue
        break
      end
    end
  queue
end

WebsocketsProxyWeb::Admin.controllers :accounts do
  get :index, map: '/' do
    if current_account && current_account.admin?
      @title = "Accounts"
      @accounts = Account.all
      render 'accounts/index'
    else
      redirect url(:sessions, :new)
    end
  end

  get :new do
    @title = pat(:new_title, :model => 'account')
    @account = Account.new
    render 'accounts/new'
  end

  post :create do
    @account = Account.new(params[:account])
    if (@account.save rescue false)
      @account.add_default_profile
      @title = pat(:create_title, :model => "account #{@account.id}")
      flash[:success] = pat(:create_success, :model => 'Account')
      params[:save_and_continue] ? redirect(url(:accounts, :index)) : redirect(url(:accounts, :edit, :id => @account.id))
    else
      @title = pat(:create_title, :model => 'account')
      flash.now[:error] = pat(:create_error, :model => 'account')
      render 'accounts/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "account #{params[:id]}")
    @account = Account[params[:id]]
    if @account
      render 'accounts/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'account', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "account #{params[:id]}")
    @account = Account[params[:id]]
    if @account
      if @account.modified! && @account.update(params[:account])
        flash[:success] = pat(:update_success, :model => 'Account', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:accounts, :index)) :
          redirect(url(:accounts, :edit, :id => @account.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'account')
        render 'accounts/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'account', :id => "#{params[:id]}")
      halt 404
    end
  end

  get :confirm, :with => :id do
    @account = Account[params[:id]]
    render 'accounts/confirm'
  end

  put :confirm, :with => :id do
    @account = Account[params[:id]]
    port = params[:account][:port]
    if port.empty?
      flash[:error] = "Account #{@account.email} has not been confirmed. Port could not be empty"
      redirect back
    else
      @account.update(port: port, confirmed: true)
      flash[:success] = "Account #{@account.email} has been confirmed"
      params[:save_and_continue] ?
          redirect(url(:accounts, :index)) :
          redirect(url(:accounts, :confirm, :id => @account.id))
    end
  end

  delete :destroy, :with => :id do
    @title = "Accounts"
    account = Account[params[:id]]
    if account
      account.destroy_all_profiles
      if account != current_account && account.destroy
        flash[:success] = pat(:delete_success, :model => 'Account', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'account')
      end
      redirect url(:accounts, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'account', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Accounts"
    unless params[:account_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'account')
      redirect(url(:accounts, :index))
    end
    ids = params[:account_ids].split(',').map(&:strip)
    accounts = Account.where(:id => ids)
    
    if accounts.include? current_account
      flash[:error] = pat(:delete_error, :model => 'account')
    elsif accounts.destroy
      flash[:success] = pat(:destroy_many_success, :model => 'Accounts', :ids => "#{ids.join(', ')}")
    end
    redirect url(:accounts, :index)
  end
  
  get :message, :with => :id do
    @account = Account[params[:id]]
    render 'accounts/message'
  end

  post :message do
    email(from: ENV['EMAIL_NAME'], to: params[:to], subject: params[:subject], body: params[:body])
    redirect url(:accounts, :index)
  end

  get :profiles, with: :id do
    @account = Account[params[:id]]
    @profiles = @account.profiles
    render 'accounts/profiles'
  end

  post :create_profile do
    if params[:name] == '' || params[:name].include?(' ')
      flash[:error] = 'Неправильное имя профиля'
    elsif !Profile.where(account_id: params[:account_id], name: params[:name]).first.nil?
      flash[:error] = 'Профиль с таким именем уже существует'
    else
      Account[params[:account_id]].add_profile(name: params[:name], queue: generate_uniq_queue)
      flash[:success] = 'Профиль создан'
    end
    redirect url(:accounts, :profiles, id: params[:account_id])
  end

  delete :remove_profile, map: '/remove_profile' do
    Profile[params[:profile_id]].destroy
    redirect url(:accounts, :profiles, id: params[:account_id])
  end

  patch :rename_profile, map: '/rename_profile' do
    Profile[params[:profile_id]].update(name: params[:name])
    redirect url(:accounts, :profiles, id: params[:account_id])
  end

end
