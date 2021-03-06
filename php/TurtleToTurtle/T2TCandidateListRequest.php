<?php
// Copyright (c) 2018, The TurtleCoin Developers
//
// Please see the included LICENSE file for more information.


# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: TurtleToTurtle.proto

namespace TurtleToTurtle;

use Google\Protobuf\Internal\GPBType;
use Google\Protobuf\Internal\RepeatedField;
use Google\Protobuf\Internal\GPBUtil;

/**
 * Generated from protobuf message <code>TurtleToTurtle.T2TCandidateListRequest</code>
 */
class T2TCandidateListRequest extends \Google\Protobuf\Internal\Message
{
    /**
     * Generated from protobuf field <code>repeated uint32 blockChainId = 1;</code>
     */
    private $blockChainId;

    /**
     * Constructor.
     *
     * @param array $data {
     *     Optional. Data for populating the Message object.
     *
     *     @type int[]|\Google\Protobuf\Internal\RepeatedField $blockChainId
     * }
     */
    public function __construct($data = NULL) {
        \GPBMetadata\TurtleToTurtle::initOnce();
        parent::__construct($data);
    }

    /**
     * Generated from protobuf field <code>repeated uint32 blockChainId = 1;</code>
     * @return \Google\Protobuf\Internal\RepeatedField
     */
    public function getBlockChainId()
    {
        return $this->blockChainId;
    }

    /**
     * Generated from protobuf field <code>repeated uint32 blockChainId = 1;</code>
     * @param int[]|\Google\Protobuf\Internal\RepeatedField $var
     * @return $this
     */
    public function setBlockChainId($var)
    {
        $arr = GPBUtil::checkRepeatedField($var, \Google\Protobuf\Internal\GPBType::UINT32);
        $this->blockChainId = $arr;

        return $this;
    }

}

