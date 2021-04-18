<?php
namespace ExampleAPI\Infrastructure\Database;

use ExampleAPI\Domain\Person\Person;
use ExampleAPI\Domain\Person\Persons;

/**
 * Interface ClientInterface
 * @package ExampleAPI\Infrastructure\Database
 */
interface ClientInterface
{
    /**
     * @param string $hash
     * @param array $data
     *
     */
    public function add(string $hash, array $data): void;

    /**
     * @param string $hash
     * @param array $data
     */
    public function update(string $hash, array $data): void;

    /**
     * @param string $hash

     * @return array
     */
    public function search(string $hash): array;

    /**
     * @return array
     */
    public function getAll(): array;

    /**
     * @param string $hash
     */
    public function delete(string $hash): void;

    /**
     * @param string $hash
     *
     * @return bool
     */
    public function exists(string $hash): bool;
}
