<?php
namespace ExampleAPI\Domain\Person;

interface PersonFactoryInterface
{
    /**
     * @param array $data
     * @return Persons
     */
    public function getAllPersonsFromRawData(array $data): Persons;

    /**
     * @param array $data
     * @return Person
     */
    public function getPersonFromRawData(array $data): Person;
}
