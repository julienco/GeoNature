<?php

/**
 * BaseCorTaxonAttribut
 * 
 * This class has been auto-generated by the Doctrine ORM Framework
 * 
 * @property integer $id_taxon
 * @property integer $id_attribut
 * @property string $valeur_attribut
 * @property BibAttributs $BibAttributs
 * @property BibTaxons $BibTaxons
 * 
 * @method integer          getIdTaxon()         Returns the current record's "id_taxon" value
 * @method integer          getIdAttribut()      Returns the current record's "id_attribut" value
 * @method string           getValeurAttribut()  Returns the current record's "valeur_attribut" value
 * @method BibAttributs     getBibAttributs()    Returns the current record's "BibAttributs" value
 * @method BibTaxons        getBibTaxons()       Returns the current record's "BibTaxons" value
 * @method CorTaxonAttribut setIdTaxon()         Sets the current record's "id_taxon" value
 * @method CorTaxonAttribut setIdAttribut()      Sets the current record's "id_attribut" value
 * @method CorTaxonAttribut setValeurAttribut()  Sets the current record's "valeur_attribut" value
 * @method CorTaxonAttribut setBibAttributs()    Sets the current record's "BibAttributs" value
 * @method CorTaxonAttribut setBibTaxons()       Sets the current record's "BibTaxons" value
 * 
 * @package    geonature
 * @subpackage model
 * @author     Gil Deluermoz
 * @version    SVN: $Id: Builder.php 7490 2010-03-29 19:53:27Z jwage $
 */
abstract class BaseCorTaxonAttribut extends sfDoctrineRecord
{
    public function setTableDefinition()
    {
        $this->setTableName('taxonomie.cor_taxon_attribut');
        $this->hasColumn('id_taxon', 'integer', 4, array(
             'type' => 'integer',
             'primary' => true,
             'length' => 4,
             ));
        $this->hasColumn('id_attribut', 'integer', 4, array(
             'type' => 'integer',
             'primary' => true,
             'length' => 4,
             ));
        $this->hasColumn('valeur_attribut', 'string', 50, array(
             'type' => 'string',
             'length' => 50,
             ));
    }

    public function setUp()
    {
        parent::setUp();
        $this->hasOne('BibAttributs', array(
             'local' => 'id_attribut',
             'foreign' => 'id_attribut'));

        $this->hasOne('BibTaxons', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));
    }
}