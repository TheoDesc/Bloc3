<?php


declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20261102100000 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Création de la table des demandes de rôles';
    }

    public function up(Schema $schema): void
    {
        $this->addSql("CREATE TABLE role_request (
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            user_id INTEGER NOT NULL,
            role VARCHAR(50) NOT NULL,
            message TEXT DEFAULT NULL,
            status VARCHAR(20) NOT NULL,
            created_at DATETIME NOT NULL,
            FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE
        )");

        $this->addSql('CREATE INDEX IDX_ROLE_REQUEST_USER ON role_request (user_id)');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('DROP TABLE role_request');
    }
}
