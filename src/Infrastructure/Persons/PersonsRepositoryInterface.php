<?php
namespace ExampleAPI\Infrastructure\Persons;

use ExampleAPI\Domain\Person\Person;
use ExampleAPI\Domain\Person\Persons;

/**
 * Interface PersonsRepositoryInterface
 * @package ExampleAPI\Infrastructure\Persons
 */
interface PersonsRepositoryInterface
{
    /**
     * Insert to database person item
     *
     * @param Person $person Person item to insert
     *
     */
    public function add(Person $person): void;

    /**
     * @param Person $old
     * @param Person $new
     */
    public function update(Person $old, Person $new): void;

    /**
     * @param Person $person
     *
     * @return Person
     */
    public function searchByHash(Person $person): Person;

    /**
     * @return Persons
     */
    public function getAll(): Persons;

    /**
     * @param Person $person
     */
    public function delete(Person $person): void;

    /**
     * @param Person $person
     *
     * @return bool
     */
    public function exists(Person $person): bool;
}
