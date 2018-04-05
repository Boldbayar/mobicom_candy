RSpec.describe MobicomCandy do
  # TEST_TOKEN
  c = MobicomCandy::Client.new('7f157d824731eff5eb6a69bec3353c9832695abef8d05c87dde2847cb59caaf9c55d05483bf800f0d6dbb4307e0e2989')
  it 'transaction' do
    r = c.transaction
    expect(r.code).to eq(0)
  end
  it 'sell' do
    r = c.sell('99999999', 'ISDN', 100)
    expect(r.code).to eq(0)
  end
  it 'sell_confirm' do
    r = c.sell_confirm('99999999', 'ISDN', 100, '123456')
    expect(r.code).to eq(0)
  end
  it 'sell_card' do
    r = c.sell_card('99999999', 'CARDID', 100, '123456')
    expect(r.code).to eq(0)
  end
  it 'customer' do
    r = c.customer('99999999', 'ISDN')
    expect(r.code).to eq(0)
  end
end
