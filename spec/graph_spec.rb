require File.dirname(__FILE__) + '/spec_helper'

require 'json'
require 'awesome_print'

describe 'Graph DB' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end 

  def setup_data
    @card1 = Card.create_card("Samys")
    @card2 = Card.create_card("Macys")
    @card3 = Card.create_card("The Gap")
    @card4 = Card.create_card("Amazon")
    @card5 = Card.create_card("Soccer.com")
    @card6 = Card.create_card("Banana Republic")
    @card7 = Card.create_card("Vons")
    @card8 = Card.create_card("Visa")

    @user1 = Card.create_user("Bob")
    @user2 = Card.create_user("Joe")
    @user3 = Card.create_user("Sally")
    @user4 = Card.create_user("Sue")
    
    Card.create_user_has_relationship(@user1, @card1, 100)
    Card.create_user_has_relationship(@user1, @card2, 100)
    Card.create_user_has_relationship(@user2, @card3, 100)
    Card.create_user_has_relationship(@user2, @card4, 100)
    Card.create_user_has_relationship(@user3, @card3, 100)
    Card.create_user_has_relationship(@user3, @card4, 100)
    Card.create_user_has_relationship(@user4, @card7, 100)
    Card.create_user_has_relationship(@user4, @card8, 100)

    Card.create_user_wants_relationship(@user1, @card3)
    Card.create_user_wants_relationship(@user1, @card4)
    Card.create_user_wants_relationship(@user2, @card1)
    Card.create_user_wants_relationship(@user2, @card5)
    Card.create_user_wants_relationship(@user2, @card6)
    Card.create_user_wants_relationship(@user3, @card7)
    Card.create_user_wants_relationship(@user3, @card8)
    Card.create_user_wants_relationship(@user4, @card1)
  end

  describe 'neo4j' do
    
    it 'should create a couple of cards and relationships between them' do
      setup_data

      user1_relationships = Neo.get_node_relationships(@user1)
      user1_relationships.count.should == 4
      
      user2_relationships = Neo.get_node_relationships(@user2)
      user2_relationships.count.should == 5
      
      user3_relationships = Neo.get_node_relationships(@user3)
      user3_relationships.count.should == 4
      
      user4_relationships = Neo.get_node_relationships(@user4)
      user4_relationships.count.should == 3
      
      users = [@user1, @user2, @user3, @user4]
      user_trade_expectations = [6, 2, 4, 4]
      for i in 0..users.length-1
        user = users[i]
        expected = user_trade_expectations[i]
        
        possible_trades = Neo.get_possible_trade_paths(user, 6)
        trades = possible_trades['data']
        
        trades.length.should == expected
        # puts "number of trades for #{user['data']['name']} = #{trades.length}"
        # trades.each do |trade|
        #   node_trade_path = []
        #   trade[0]['nodes'].each do |node|
        #       node_id = node.split('/').last.to_i
        #       node_obj = Neo.get_node(node_id)
        #       node_trade_path << node_obj['data']['name']
        #   end
        #   puts "  #{node_trade_path.join(' --> ')}"
        # end
        #ap possible_trades
        #puts "-"* 20
      end
    end
    
    it 'should create neo4j user when standard user is created' do
      user = User.create(:username   => 'uname',
                        :password   => 'password',
                        :first_name => 'first',
                        :last_name  => 'last',
                        :email      => 'email@test.com')
      
      user.neo_id.should_not == nil
      user.neo_id.should > 0 
      
      neo_user = Neo.get_node(user.neo_id)
      neo_user.should_not == nil
      neo_user['data']['name'].should == user.username
    end
    
    it 'should update graph user when standard user is updated' do
      user = User.create(:username   => 'uname',
                        :password   => 'password',
                        :first_name => 'first',
                        :last_name  => 'last',
                        :email      => 'email@test.com')
            
      neo_user = Neo.get_node(user.neo_id)
      neo_user['data']['name'].should == user.username

      user.username = 'new_username'
      user.save
      
      neo_user = Neo.get_node(user.neo_id)
      neo_user['data']['name'].should == user.username
    end
    
    it 'should destroy graph user when standard user is destroyed' do
      user = User.create(:username   => 'uname',
                        :password   => 'password',
                        :first_name => 'first',
                        :last_name  => 'last',
                        :email      => 'email@test.com')
      
      neo_id = user.neo_id
      neo_user = Neo.get_node(user.neo_id)
      neo_user.should_not == nil

      user.destroy
      neo_user = Neo.get_node(neo_id)
      neo_user.should == nil    end
        
  end
  
  it 'should find card node by name when card does exist' do
    setup_data
    id = Card.find_card_id_by_name('Amazon')    
    id.should > 0
    
    card = Card.get_card_by_id(id)
    card.should_not == nil
  end

  it 'should NOT find card node by name if the card does not exist' do
    setup_data
    id = Card.find_card_id_by_name('bootycard')    
    id.should == nil
  end
  
  it 'should find cards a given user has' do
    setup_data
    
    user_id = @user1['self'].split('/').last.to_i
    cards = Card.find_cards_by_user_has(user_id)
    cards.count.should == 2
    
    cards.each do |card|
      ['Samys', 'Macys'].include?(card.first['data']['name']).should be_true
    end
  end

  it 'should find cards a give user wants' do
    setup_data
    user_id = @user2['self'].split('/').last.to_i
    cards = Card.find_cards_by_user_wants(user_id)
    cards.count.should == 3
    
    cards.each do |card|
      ['Samys', 'Soccer.com', 'Banana Republic'].include?(card.first['data']['name']).should be_true
    end
    
  end
  
  it 'should return all cards in system' do
    setup_data
    all_cards = Card.get_all_cards
    all_cards.count.should == 8
  end
  
  xit 'should delete a has relationship' do
    setup_data
    
    user1_relationships = Neo.get_node_relationships(@user1)
    user1_relationships.count.should == 4

    user_id = @user1['self'].split('/').last.to_i
    card_id = @card1['self'].split('/').last.to_i
    
    puts "user: #{user_id}"
    puts "card: #{card_id}"
    u_to_c = Card.find_user_card_relationship(user_id, card_id)
    ap u_to_c
    
    cards = Card.find_cards_by_user_has(user_id)
    cards.count.should == 2
    
    Card.remove_wanted_card(card_id)
    
    cards = Card.find_cards_by_user_has(user_id)
    cards.count.should == 1
    
  end
  
  it 'should delete a wants relationship' do
    setup_data
  end
  
end
