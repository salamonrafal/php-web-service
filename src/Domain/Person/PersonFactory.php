<?php
namespace ExampleAPI\Domain\Person;

/**
 * Class PersonFactory
 * @package ExampleAPI\Domain\Person
 */
class PersonFactory implements PersonFactoryInterface
{
    /**
     * @inheritdoc
     */
    public function getAllPersonsFromRawData(array $rawData): Persons
    {
        $persons = new Persons();

        for ($i = 0; $i < count($rawData); $i++) {
            $persons[] = $this->createPerson($rawData[$i]);
        }

        return $persons;
    }

    /**
     * @inheritdoc
     */
    public function getPersonFromRawData(array $rawData): Person
    {
        return $this->createPerson($rawData);
    }

    /**
     * @param array $data
     * @return Person
     */
    private function createPerson(array $data): Person
    {
        $name = $this->getField('name', $data);
        $surname = $this->getField('surname', $data);
        $age = $this->getField('age', $data);

        return new Person($name, $surname, $age);
    }

    /**
     * @param string $name
     * @param array $data
     * @return mixed|null
     */
    private function getField(string $name, array $data)
    {
        if (array_key_exists($name, $data)) {
            return $data[$name];
        }

        return null;
    }
}
