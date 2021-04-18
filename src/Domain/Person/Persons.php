<?php
namespace ExampleAPI\Domain\Person;

use ArrayAccess;
use Exception;
use JsonSerializable;

/**
 * Class Persons
 * @package ExampleAPI\Domain\Person
 */
class Persons implements ArrayAccess, JsonSerializable
{
    /**
     * @var array
     */
    private array $data = [];

    /**
     * @inheritdoc
     */
    public function offsetExists($offset)
    {
        if (array_key_exists($offset, $this->data)) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @inheritdoc
     *
     * @throws Exception
     */
    public function offsetGet($offset)
    {
        if ($this->offsetExists($offset)) {
            return $this->data[$offset];
        } else {
            throw new Exception('Missing element', 404);
        }
    }

    /**
     * @inheritdoc
     */
    public function offsetSet($offset, $value)
    {
        $this->data[$offset] = $value;
    }

    /**
     * @inheritdoc
     */
    public function offsetUnset($offset)
    {
        if ($this->offsetExists($offset)) {
            unset($this->data[$offset]);
        }
    }

    /**
     * @inheritdoc
     */
    public function jsonSerialize()
    {
        return $this->data;
    }
}
