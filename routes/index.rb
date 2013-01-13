get '/' do
  if @current_user
    user_id = @current_user.neo_id
  
    @cards_has   = Card.find_cards_by_user_has(user_id)
    @cards_wants = Card.find_cards_by_user_wants(user_id)
    
    user = Neo.get_node(user_id)
    possible_trades = Neo.get_possible_trade_paths(user, 6)
    @trades = possible_trades['data']
    
    @other_cards = Card.get_all_cards
    @other_cards = @other_cards.select {|card| !@cards_has.include?(card) }
    @other_cards = @other_cards.select {|card| !@cards_wants.include?(card) }
  end  
  
  erb :index
end

