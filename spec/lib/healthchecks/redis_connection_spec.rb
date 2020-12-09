RSpec.describe Healthchecks::RedisConnection do
  it "returns 'ok' status" do
    expect(described_class.new.status).to eq(:ok)
  end

  it "returns 'critical' status if unable to connect to Redis" do
    allow(Redis).to receive(:new).and_raise(Redis::CannotConnectError)

    expect(described_class.new.status).to eq(:critical)
  end
end
