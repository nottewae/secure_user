class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def pink
    colorize(35)
  end
end
class UserGenerator < Rails::Generators::Base
  def setup





    puts "all matching records will be overwritten!".upcase.red
    model_name = ask("Model name? [user]")
    model_name = "user" if model_name.blank?
    login_field_name = ask("Field name for login? [login]")
    login_field_name = "login" if login_field_name.blank?
    templater=ask("your templater? [slim]     (view sign_in generating only for slim^ write all other for cancel generation this view)")
    templater = "slim" if templater.blank?
    model_exists= File.exist?("app/models/#{model_name}.rb")


    if model_exists

      puts "model exist"
      migrations=[]
      puts "listen old migrations"
      puts %x"rails d model #{model_name}"
      generate "migration drop_#{model_name.pluralize} --force"
      Dir.foreach("db/migrate"){|x|migrations<<x}
      delete_migration_name=''
      migrations.each do |l|
        puts l
        delete_migration_name=l if l.include?("drop_#{model_name.pluralize}")
      end
      puts "my migration file:#{delete_migration_name}"
      if !delete_migration_name.blank?
        inject_into_file "db/migrate/#{delete_migration_name}",after:'change' do
          <<-FILE

    drop_table :#{model_name.pluralize}
FILE
        end
      else
        puts "ERROR!!!!"
        raise "Ah no!"
      end
      rake "db:migrate"
    end
    other_fields=ask("Do You want adding more fields in model (as generator example:'field:integer:index other_filed:string') if no just press enter?")
    generate "scaffold #{model_name}  #{login_field_name}:string:index password:string salt:string #{other_fields} --skip"
    generate "migration add_timestamps_to#{model_name}"
    puts "migration file name", model_exists
    rake "db:migrate"
    password_mix_key = ask("Your secret key for password generation? [___-o-!-o-___]")
    password_mix_key="___----___" if password_mix_key.blank?
    inject_into_file "app/models/#{model_name}.rb", after:"class #{model_name.capitalize} < ActiveRecord::Base" do
      <<-FILE


  before_create :encrypt_password
  validates :#{login_field_name},:password, uniqueness: true
  validates :#{login_field_name}, length: {minimum: 3}
  validates :password, length: {minimum: 6}
  def login?(password)
      self.password==Digest::SHA2.hexdigest(password+self.salt) ? true:false
  end
  private
    def encrypt_password
      self.salt=Digest::SHA2.hexdigest Time.now.to_i.to_s+"#{password_mix_key}"
      self.password=Digest::SHA2.hexdigest self.password+self.salt
    end
FILE
    end

    inject_into_file "app/controllers/#{model_name.pluralize}_controller.rb", after:"before_action :set_admin, only: [:show, :edit, :update, :destroy, :login]" do
      <<-FILE

  def sign_in

  end
  def login
    @#{model_name}=#{model_name.capitalize}.find_by_#{login_field_name} #{model_name}_params[:#{login_field_name}]
    if @#{model_name}.login?(#{model_name}_params[:password])
      redirect_to :sign_in
    else
      #TODO Your action after login
      render text:"Success"
    end
  end
FILE
    end

  inject_into_file "config/routes.rb", before:"resources :#{model_name.pluralize}" do
    <<-FILE

  get '/sign_in'=>'#{model_name.pluralize}#sign_in', as:'#{model_name}_sign_in'
  post '/login'=>'#{model_name.pluralize}#login', as:'#{model_name}_login'

  FILE
  end
    if templater=="slim"
    create_file "app/views/#{model_name.pluralize}/sign_in.html.slim",<<-FILE
= form_for :#{model_name}, url:#{model_name}_login_path do |f|
  .form-group
    =f.label :#{login_field_name}, '#{login_field_name.capitalize}'
    =f.text_field :#{login_field_name},class:'form-group'
  .form-group
    =f.label :password, 'Password'
    =f.password_field :password,class:'form-group'
  .form-group
    =f.submit 'Sign In',class:"btn btn-success"
    FILE
    end
    end





end