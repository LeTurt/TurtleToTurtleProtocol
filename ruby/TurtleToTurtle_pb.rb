# Copyright (c) 2018, The TurtleCoin Developers
#
# Please see the included LICENSE file for more information.

# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: TurtleToTurtle.proto

require 'google/protobuf'

require 'TurtleCoin_pb'
Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "TurtleToTurtle.T2TDatagram" do
    optional :p2pNetworkId, :uint32, 1
    optional :version, :uint32, 2
    optional :peerId, :string, 3
    optional :agent, :string, 4
    optional :nodeVersion, :string, 5
    oneof :dataPayload do
      optional :t2tCandidateList, :message, 6, "TurtleToTurtle.T2TCandidateList"
      optional :t2tCandidateListRequest, :message, 7, "TurtleToTurtle.T2TCandidateListRequest"
      optional :blockChainPayload, :message, 8, "TurtleToTurtle.BlockChainPayload"
    end
  end
  add_message "TurtleToTurtle.T2TCandidateList" do
    repeated :candidate, :message, 1, "TurtleToTurtle.T2TCandidate"
  end
  add_message "TurtleToTurtle.T2TCandidateListRequest" do
    repeated :blockChainId, :uint32, 1
  end
  add_message "TurtleToTurtle.T2TCandidate" do
    optional :peerId, :string, 1
    optional :version, :uint32, 2
    optional :ipV4Address, :uint32, 3
    optional :ipV6Address, :string, 4
    optional :port, :uint32, 5
    optional :ttl, :uint32, 6
    optional :capability, :message, 7, "TurtleToTurtle.T2TNodeCapability"
  end
  add_message "TurtleToTurtle.T2TNodeCapability" do
    optional :archival, :bool, 1
    repeated :blockChainId, :uint32, 2
  end
  add_message "TurtleToTurtle.BlockChainPayload" do
    optional :blockChainId, :uint32, 1
    oneof :data do
      optional :block, :message, 2, "TurtleToTurtle.TurtleCoin.TurtleBlock"
      optional :transaction, :message, 3, "TurtleToTurtle.TurtleCoin.TurtleTransaction"
    end
  end
end

module TurtleToTurtle
  T2TDatagram = Google::Protobuf::DescriptorPool.generated_pool.lookup("TurtleToTurtle.T2TDatagram").msgclass
  T2TCandidateList = Google::Protobuf::DescriptorPool.generated_pool.lookup("TurtleToTurtle.T2TCandidateList").msgclass
  T2TCandidateListRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("TurtleToTurtle.T2TCandidateListRequest").msgclass
  T2TCandidate = Google::Protobuf::DescriptorPool.generated_pool.lookup("TurtleToTurtle.T2TCandidate").msgclass
  T2TNodeCapability = Google::Protobuf::DescriptorPool.generated_pool.lookup("TurtleToTurtle.T2TNodeCapability").msgclass
  BlockChainPayload = Google::Protobuf::DescriptorPool.generated_pool.lookup("TurtleToTurtle.BlockChainPayload").msgclass
end
