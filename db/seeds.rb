email     = shell.ask "Which email do you want use for logging into admin?"
password  = shell.ask "Tell me the password to use:", :echo => false

shell.say ""

account = Account.new(email: email, password: password, password_confirmation: password, role: "admin", port: nil)

if account.valid?
  account.save
  shell.say "================================================================="
  shell.say "Account has been successfully created, now you can login with:"
  shell.say "================================================================="
  shell.say "   email: #{email}"
  shell.say "   password: #{?* * password.length}"
  shell.say "================================================================="
else
  shell.say "Sorry, but something went wrong!"
  shell.say ""
  account.errors.full_messages.each { |m| shell.say "   - #{m}" }
end

shell.say ""
