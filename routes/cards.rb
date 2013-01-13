get '/cards/' do  
  user_id = @current_user.neo_id
  
  @cards_has   = Card.find_cards_by_user_has(user_id)
  @cards_wants = Card.find_cards_by_user_wants(user_id)
  
  erb :cards
end

get '/cards/have/new/' do
  erb :new_card
end

post '/cards/have/new/' do
  name = params[:name]
  amount = params[:amount]
  amount = amount.gsub(/[^0-9. ]/i, '')
  
  if amount.length == 0 or name.length == 0
    flash[:error] = 'YOU MUST ENTER A CARD NAME AND A VALID NUMERIC VALUE FOR THE CARD AMOUNT!'
    redirect '/'
  end
  
  user = Neo.get_node(@current_user.neo_id)
  
  card_id = Card.find_card_id_by_name(name)
  if card_id
    card = Card.get_card_by_id(card_id)
  else
    card = Card.create_card(name)
  end
  
  Card.create_user_has_relationship(user, card, amount)
  
  flash[:notice] = "A #{name} card for $#{sprintf("%.2f", amount)} was added to your list of cards you would like to give in trade."
  
  redirect '/'
end

get '/cards/want/new/' do
  erb :new_card_want
end

get '/cards/want/add/:id/' do
  card_id = params[:id]
  card = Card.get_card_by_id(card_id)
  name = card['data']['name']
  user = Neo.get_node(@current_user.neo_id)

  Card.create_user_wants_relationship(user, card)
  
  flash[:notice] = "The #{name} card was added to your list of cards you would like to trade for."
  
  redirect '/'  
end

post '/cards/want/new/' do
  name = params[:name]
  
  if name.length == 0
    flash[:error] = 'YOU MUST ENTER A CARD NAME FOR THE!'
    redirect '/'
  end
  
  user = Neo.get_node(@current_user.neo_id)
  
  card_id = Card.find_card_id_by_name(name)
  if card_id
    card = Card.get_card_by_id(card_id)
  else
    card = Card.create_card(name)
  end
  
  Card.create_user_wants_relationship(user, card)
  
  flash[:notice] = "The #{name} card was added to your list of cards you would like to trade for."
  
  redirect '/'
end
