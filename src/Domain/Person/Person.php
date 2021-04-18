<?php
namespace ExampleAPI\Domain\Person;

use JsonSerializable;

/**
 * Class Person
 * @package ExampleAPI\Domain\Person
 */
class Person implements JsonSerializable
{
    /**
     * @var string
     */
    private string $name;

    /**
     * @var string
     */
    private string $surname;

    /**
     * @var int
     */
    private int $age;

    /**
     * Person constructor.
     * @param string|null $name
     * @param string|null $surname
     * @param int|null $age
     */
    public function __construct(string $name = null, string $surname = null, int $age = null)
    {
        if (!is_null($name)) {
            $this->name = $name;
        }

        if (!is_null($surname)) {
            $this->surname = $surname;
        }

        if (!is_null($age)) {
            $this->age = $age;
        }
    }

    /**
     * @return string
     */
    public function getName(): string
    {
        return $this->name;
    }

    /**
     * @return string
     */
    public function getSurname(): string
    {
        return $this->surname;
    }

    /**
     * @return int
     */
    public function getAge(): int
    {
        return $this->age;
    }

    /**
     * @inheritdoc
     */
    public function jsonSerialize()
    {
        return [
            'name' => $this->getName(),
            'surname' => $this->getSurname(),
            'age' => $this->getAge()
        ];
    }
}
