<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260921090036 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Suppression de la table article';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('DROP TABLE article');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('CREATE TABLE article (
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            titre VARCHAR(255) NOT NULL,
            description TEXT NOT NULL,
            auteur VARCHAR(255) NOT NULL,
            date_publication DATETIME NOT NULL,
            photo VARCHAR(255) DEFAULT NULL
        )');
    }
}
