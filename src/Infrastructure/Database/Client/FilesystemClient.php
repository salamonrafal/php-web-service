<?php
namespace ExampleAPI\Infrastructure\Database\Client;

use ExampleAPI\Infrastructure\Database\ClientInterface;
use Symfony\Component\Config\Definition\ConfigurationInterface;

/**
 * Class FilesystemClient
 *
 * @package ExampleAPI\Infrastructure\Database\Client
 */
class FilesystemClient implements ClientInterface
{
    private ConfigurationInterface $configuration;

    public function __construct(ConfigurationInterface $configuration)
    {
        $this->configuration = $configuration;
    }

    /**
     * @inheritdoc
     */
    public function add(string $hash, array $data): void
    {
        // TODO: Implement add() method.
    }

    /**
     * @inheritdoc
     */
    public function update(string $hash, array $data): void
    {
        // TODO: Implement update() method.
    }

    /**
     * @inheritdoc
     */
    public function search(string $hash): array
    {
        // TODO: Implement search() method.
    }

    /**
     * @inheritdoc
     */
    public function delete(string $hash): void
    {
        // TODO: Implement delete() method.
    }

    /**
     * @inheritdoc
     */
    public function exists(string $hash): bool
    {
        // TODO: Implement exists() method.
    }

    public function getAll(): array
    {
        // TODO: Implement getAll() method.
    }
}
