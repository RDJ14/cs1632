require_relative "Block"


class Vericator

  def initialize()
  end

  def verify_arg inputArray
    if(inputArray.length != 1)
      return false
    end
    fileName = inputArray[0]
    fileArray = fileName.split('.')
    if(fileArray.length != 2)
      return false
    end
    if(fileArray[1].eql? "txt")
      return true
    else
      return false
    end
  end

  def read_file fileName
    fileLines = File.readlines(fileName)
    return fileLines
    rescue
      puts "The file #{fileName} could not be opened. Are you sure it exists?"
      exit
  end

  def split_block block
    splitBlock = block.split('|')
    return splitBlock
  end

  def verify_starting_block block
    if((block.blockNumber) != "0")
      return "Invalid block number for Genesis Block"
    elsif((block.previousHash) != "0")
      return "Invalid previous hash for Genesis Block"
    else
      return true
    end
  end

  def verify_rest_of_chain blockAr
	  blockAr.each_with_index { |blk, idx| break if idx + 1 == blockAr.length # Don't overrun array
		  # Check if our endHash == next block's previousHash
		  # If there's a hash mismatch, raise an exception
		  if blk[idx].endHash != blk[idx + 1].previousHash
			  raise "Block #{idx + 1}'s previous hash (#{blk[idx + 1].previousHash}) does not " + 
				  "match block #{idx}'s end hash (#{blk[idx].endHash})"
		  end
	  
		  # Check for valid transaction amounts
		  buffer = blockAr[idx].transactions
		  while not buffer.isEmpty?
			giver = buffer.chomp!(">")
			taker = buffer.chomp!("(")
			amount = buffer.chomp!(")").to_i

			# Check transaction format
			raise "Invalid Billcoin giver: #{giver}" if giver.to_s == nil
			raise "Invalid Billcoin taker: #{taker}" if taker.to_s == nil
			raise "Invalid Billcoin amount: #{amount}" if giver.to_i == nil

			if (not giver.eql? "SYSTEM") &&  (hashMap[giver] - amount < 0)
				# Check if the giver has enough coins for the transaction
				# unless its the system
				raise "#{giver} does not have enough Billcoins for this transaction"
			end
			# Unless the system is giving billcoins, subtract the amount from
			# the giver's wallet
			hashMap[giver] = hashMap[giver] - amount unless giver.eql? "SYSTEM"
			hashMap[taker] = hashMap[taker] + amount

			# Break if there aren't more transactions
			break unless buffer.chomp!(":") != nil
		  end
	  }
	  return hashMap
  end

  def create_block someBlock
    if(someBlock.length != 5)
      return nil
    end
    returnBlock = Block.new(someBlock[0], someBlock[1], someBlock[2], someBlock[3], someBlock[4])
    return returnBlock
  end

end
