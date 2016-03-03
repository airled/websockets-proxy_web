require 'spec_helper'

RSpec.describe "Welcome Controller" do

  it "should allow accessing '/'" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Добро пожаловать!')
  end

  it "should allow accessing '/docs'" do
    get '/docs'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Документация')
  end

  it "should not allow accessing '/profile' if user is not signed in" do
    get '/profile'
    expect(last_response.status).to eq(302)
  end

  it "should allow accessing '/plugin'" do
    get '/plugin'
    expect(last_response).to be_ok
  end

  it "should allow accessing '/pending'" do
    get '/pending'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Ваш аккаунт еще не подтвержден.')
  end

  it "should not allow accessing '/message' if user is not signed in" do
    get '/message'
    expect(last_response.status).to eq(302)
  end

  it "should allow accessing '/create_user'" do
    get '/create_user'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Регистрация')
  end

end
