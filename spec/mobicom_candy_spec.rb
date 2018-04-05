RSpec.describe MobicomCandy do
  it 'check api endpoints' do
    c = MobicomCandy::Client.new(ENV['CANDY_TOKEN'])
    c.customer('99030641', 'ISDN').to_json
    expect(true).to eq(true)
  end
end
