<?php
namespace ExampleAPI\Infrastructure\Persons;

use ExampleAPI\Domain\Person\Person;
use ExampleAPI\Domain\Person\PersonFactoryInterface;
use ExampleAPI\Domain\Person\Persons;
use ExampleAPI\Infrastructure\Database\ClientInterface;

/**
 * Class PersonsRepository
 * @package ExampleAPI\Infrastructure\Persons
 */
class PersonsRepository implements PersonsRepositoryInterface
{
    /**
     * @var ClientInterface
     */
    private ClientInterface $client;

    /**
     * @var PersonFactoryInterface
     */
    private PersonFactoryInterface $personFactory;

    /**
     * PersonsRepository constructor.
     * @param ClientInterface $client
     * @param PersonFactoryInterface $personFactory
     */
    public function __construct(
        ClientInterface $client,
        PersonFactoryInterface $personFactory
    ) {
        $this->client = $client;
        $this->personFactory = $personFactory;
    }

    /**
     * @inheritDoc
     */
    public function add(Person $person): void
    {
        $this->client->add($this->createHash($person), $person->jsonSerialize());
    }

    /**
     * @inheritDoc
     */
    public function update(Person $old, Person $new): void
    {
        $this->client->update($this->createHash($old), $new->jsonSerialize());
    }

    /**
     * @inheritDoc
     */
    public function searchByHash(Person $person): Person
    {
        return $this->personFactory->getPersonFromRawData(
            $this->client->search($this->createHash($person))
        );
    }

    /**
     * @inheritDoc
     */
    public function delete(Person $person): void
    {
        $this->client->delete($this->createHash($person));
    }

    /**
     * @inheritDoc
     */
    public function exists(Person $person): bool
    {
        return $this->client->exists($this->createHash($person));
    }

    /**
     * @inheritDoc
     */
    public function getAll(): Persons
    {
        return $this->personFactory->getAllPersonsFromRawData(
            $this->client->getAll()
        );
    }

    /**
     * @param Person $person
     * @return string
     */
    private function createHash(Person $person): string
    {
        return hash("sha256", $person);
    }
}
