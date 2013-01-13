class User
  include DataMapper::Resource
  
  property :id,         Serial
  property :neo_id,     Integer
  property :username,   String, :required => true, :unique => true
  property :password,   String, :required => true
  property :first_name, String, :required => true
  property :last_name,  String, :required => true
  property :email,      String, :required => true, :unique => true, :format => :email_address
  property :created_at, DateTime
    
  def full_name
    self.first_name + ' ' + self.last_name
  end
  
  def neo_user
    Neo.get_node(self.neo_id)
  end
   
   before :create do
     n = Card.create_user(self.username)
     self.neo_id = n['self'].split('/').last.to_i
   end
   
   after :update do
     n = Neo.get_node(self.neo_id)
     Neo.reset_node_properties(n, {"name" => username})
   end
   
   before :destroy do
     n = Neo.get_node(self.neo_id)
     Neo.delete_node!(n)
   end
end
