<?php

/**
 * BaseTaxrefProtectionArticles
 * 
 * This class has been auto-generated by the Doctrine ORM Framework
 * 
 * @property string $cd_protection
 * @property string $article
 * @property string $intitule
 * @property string $arrete
 * @property string $url_inpn
 * @property integer $cd_doc
 * @property string $url
 * @property integer $date_arrete
 * @property string $type_protection
 * @property boolean $concerne_mon_territoire
 * @property Doctrine_Collection $TaxrefProtectionEspeces
 * 
 * @method string                   get()                        Returns the current record's "cd_protection" value
 * @method string                   get()                        Returns the current record's "article" value
 * @method string                   get()                        Returns the current record's "intitule" value
 * @method string                   get()                        Returns the current record's "arrete" value
 * @method string                   get()                        Returns the current record's "url_inpn" value
 * @method integer                  get()                        Returns the current record's "cd_doc" value
 * @method string                   get()                        Returns the current record's "url" value
 * @method integer                  get()                        Returns the current record's "date_arrete" value
 * @method string                   get()                        Returns the current record's "type_protection" value
 * @method boolean                  get()                        Returns the current record's "concerne_mon_territoire" value
 * @method Doctrine_Collection      get()                        Returns the current record's "TaxrefProtectionEspeces" collection
 * @method TaxrefProtectionArticles set()                        Sets the current record's "cd_protection" value
 * @method TaxrefProtectionArticles set()                        Sets the current record's "article" value
 * @method TaxrefProtectionArticles set()                        Sets the current record's "intitule" value
 * @method TaxrefProtectionArticles set()                        Sets the current record's "arrete" value
 * @method TaxrefProtectionArticles set()                        Sets the current record's "url_inpn" value
 * @method TaxrefProtectionArticles set()                        Sets the current record's "cd_doc" value
 * @method TaxrefProtectionArticles set()                        Sets the current record's "url" value
 * @method TaxrefProtectionArticles set()                        Sets the current record's "date_arrete" value
 * @method TaxrefProtectionArticles set()                        Sets the current record's "type_protection" value
 * @method TaxrefProtectionArticles set()                        Sets the current record's "concerne_mon_territoire" value
 * @method TaxrefProtectionArticles set()                        Sets the current record's "TaxrefProtectionEspeces" collection
 * 
 * @package    geonature
 * @subpackage model
 * @author     Gil Deluermoz
 * @version    SVN: $Id: Builder.php 7490 2010-03-29 19:53:27Z jwage $
 */
abstract class BaseTaxrefProtectionArticles extends sfDoctrineRecord
{
    public function setTableDefinition()
    {
        $this->setTableName('taxonomie.taxref_protection_articles');
        $this->hasColumn('cd_protection', 'string', 20, array(
             'type' => 'string',
             'primary' => true,
             'length' => 20,
             ));
        $this->hasColumn('article', 'string', 100, array(
             'type' => 'string',
             'length' => 100,
             ));
        $this->hasColumn('intitule', 'string', null, array(
             'type' => 'string',
             'length' => '',
             ));
        $this->hasColumn('arrete', 'string', null, array(
             'type' => 'string',
             'length' => '',
             ));
        $this->hasColumn('url_inpn', 'string', 250, array(
             'type' => 'string',
             'length' => 250,
             ));
        $this->hasColumn('cd_doc', 'integer', 4, array(
             'type' => 'integer',
             'length' => 4,
             ));
        $this->hasColumn('url', 'string', 250, array(
             'type' => 'string',
             'length' => 250,
             ));
        $this->hasColumn('date_arrete', 'integer', 4, array(
             'type' => 'integer',
             'length' => 4,
             ));
        $this->hasColumn('type_protection', 'string', 250, array(
             'type' => 'string',
             'length' => 250,
             ));
        $this->hasColumn('concerne_mon_territoire', 'boolean', 1, array(
             'type' => 'boolean',
             'length' => 1,
             ));
    }

    public function setUp()
    {
        parent::setUp();
        $this->hasMany('TaxrefProtectionEspeces', array(
             'local' => 'cd_protection',
             'foreign' => 'cd_protection'));
    }
}