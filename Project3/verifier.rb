require_relative "Block"
require_relative "vericator"

def print hashMap
  hashMap.each{ |address, coins| puts "#{address}: #{coins} billcoins"}
end

#Main
veri = Vericator.new()

inputArray = ARGV
if(! veri.verify_arg(inputArray))
  puts "Invalid argument. Enter 1 argument that is the file containing the blockchain transactions"
  exit!
end

fileName = inputArray[0]
blocks = veri.read_file(fileName)
blockArray = []
for i in 0..(blocks.length - 1) do
  someBlock = veri.split_block(blocks[i])
  aBlock = Block.create_block(someBlock)
  if(aBlock == nil)
    puts "Block #{i} was not properly formatted"
    exit!
  end
  blockArray[i] = aBlock
end

startingBlockOK = veri.verify_starting_block(blockArray[0])

if(startingBlockOK != true)
  puts startingBlockOK
  exit!
end

# Make sure blocks are in right order
veri.verify_order blockArray 

# Make sure previous hashes match end hashes
veri.verify_hashes blockArray 

# Verify that wallets are not overdrawn
hashMap = veri.verify_wallet_amounts blockArray

# Make sure hashMap is a valid hash
raise "Could not verify blockchain" unless hashMap.is_a? Hash

# Print output
print(hashMap)

exit!
