get '/trades/' do
  user_id = @current_user.neo_id
  user = Neo.get_node(user_id)
  
  possible_trades = Neo.get_possible_trade_paths(user, 6)
  @trades = possible_trades['data']
  
  erb :trades
end